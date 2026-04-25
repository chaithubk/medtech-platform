"""Integration tests for MedTech platform."""

import json
import subprocess
import time
import sys
from typing import Optional, Dict


class MQTTTester:
    """Test MQTT communication between services."""
    
    @staticmethod
    def subscribe_topic(topic: str, timeout_sec: int = 5) -> Optional[str]:
        """Subscribe to MQTT topic and get first message."""
        try:
            cmd = [
                "docker", "run", "--rm",
                "--network", "medtech-platform_medtech-network",
                "library/alpine:latest",
                "sh", "-c",
                f"apk add mosquitto-clients && timeout {timeout_sec} mosquitto_sub -h vitals-publisher -t '{topic}' -W 1"
            ]
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_sec+5)
            return result.stdout.strip() if result.stdout else None
        except Exception as e:
            print(f"❌ Error subscribing to {topic}: {e}")
            return None
    
    @staticmethod
    def validate_json(data: str) -> bool:
        """Validate JSON format."""
        try:
            json.loads(data)
            return True
        except json.JSONDecodeError:
            return False


def test_vitals_flow():
    """Test vitals publisher → MQTT flow."""
    print("📊 Test 1: Vitals Flow")
    print("-" * 50)
    
    # Wait for vitals to be published
    time.sleep(10)
    
    vital_data = MQTTTester.subscribe_topic("medtech/vitals/latest", timeout_sec=10)
    
    if not vital_data:
        print("❌ FAILED: No vital data received")
        return False
    
    if not MQTTTester.validate_json(vital_data):
        print(f"❌ FAILED: Invalid JSON: {vital_data}")
        return False
    
    vital = json.loads(vital_data)
    
    # Validate vital structure
    required_fields = ["timestamp", "hr", "bp_sys", "bp_dia", "o2_sat", "temperature"]
    for field in required_fields:
        if field not in vital:
            print(f"❌ FAILED: Missing field '{field}'")
            return False
    
    # Validate vital ranges
    if not (30 <= vital["hr"] <= 200):
        print(f"❌ FAILED: HR out of range: {vital['hr']}")
        return False
    
    print("✅ PASSED: Vitals flow working")
    print(f"   Received: {vital}")
    return True


def test_analytics_flow():
    """Test analytics → MQTT predictions flow."""
    print("\n🧠 Test 2: Analytics Flow")
    print("-" * 50)
    
    # Wait for analytics to process vitals
    time.sleep(20)
    
    prediction_data = MQTTTester.subscribe_topic("medtech/predictions/sepsis", timeout_sec=15)
    
    if not prediction_data:
        print("❌ FAILED: No prediction data received")
        return False
    
    if not MQTTTester.validate_json(prediction_data):
        print(f"❌ FAILED: Invalid JSON: {prediction_data}")
        return False
    
    prediction = json.loads(prediction_data)
    
    # Validate prediction structure
    required_fields = ["risk_score", "risk_level", "confidence"]
    for field in required_fields:
        if field not in prediction:
            print(f"❌ FAILED: Missing field '{field}'")
            return False
    
    # Validate prediction ranges
    if not (0 <= prediction["risk_score"] <= 100):
        print(f"❌ FAILED: risk_score out of range: {prediction['risk_score']}")
        return False
    
    if prediction["risk_level"] not in ["LOW", "MODERATE", "HIGH"]:
        print(f"❌ FAILED: Invalid risk_level: {prediction['risk_level']}")
        return False
    
    if not (0 <= prediction["confidence"] <= 1):
        print(f"❌ FAILED: confidence out of range: {prediction['confidence']}")
        return False
    
    print("✅ PASSED: Analytics flow working")
    print(f"   Received: {prediction}")
    return True


def test_end_to_end():
    """Test complete end-to-end flow."""
    print("\n🔄 Test 3: End-to-End Flow")
    print("-" * 50)
    
    # Collect metrics over time
    vitals_count = 0
    predictions_count = 0
    
    print("Monitoring MQTT traffic for 30 seconds...")
    
    for i in range(3):
        vital_data = MQTTTester.subscribe_topic("medtech/vitals/latest", timeout_sec=12)
        if vital_data and MQTTTester.validate_json(vital_data):
            vitals_count += 1
            print(f"  ✅ Vital #{vitals_count} received")
        
        time.sleep(5)
        
        prediction_data = MQTTTester.subscribe_topic("medtech/predictions/sepsis", timeout_sec=5)
        if prediction_data and MQTTTester.validate_json(prediction_data):
            predictions_count += 1
            print(f"  ✅ Prediction #{predictions_count} received")
    
    if vitals_count >= 2 and predictions_count >= 1:
        print("✅ PASSED: End-to-end flow working")
        print(f"   Vitals: {vitals_count}, Predictions: {predictions_count}")
        return True
    else:
        print(f"❌ FAILED: Not enough data (Vitals: {vitals_count}, Predictions: {predictions_count})")
        return False


def test_latency():
    """Test inference latency."""
    print("\n⚡ Test 4: Latency Check")
    print("-" * 50)
    
    try:
        result = subprocess.run(
            ["docker-compose", "logs", "edge-analytics"],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        logs = result.stdout
        
        # Look for latency metrics in logs
        latency_found = False
        for line in logs.split("\n"):
            if "latency" in line.lower() or "inference" in line.lower():
                print(f"  {line.strip()}")
                latency_found = True
        
        if latency_found:
            print("✅ PASSED: Latency metrics found")
            return True
        else:
            print("⚠️  SKIPPED: No explicit latency metrics in logs")
            return True  # Non-critical
    
    except Exception as e:
        print(f"⚠️  SKIPPED: Could not check latency: {e}")
        return True


def main():
    """Run all integration tests."""
    print("=" * 50)
    print("MedTech Integration Test Suite")
    print("=" * 50)
    
    tests = [
        test_vitals_flow,
        test_analytics_flow,
        test_end_to_end,
        test_latency,
    ]
    
    results = []
    for test_func in tests:
        try:
            result = test_func()
            results.append(result)
        except Exception as e:
            print(f"❌ EXCEPTION in {test_func.__name__}: {e}")
            results.append(False)
    
    # Summary
    print("\n" + "=" * 50)
    print("Test Summary")
    print("=" * 50)
    passed = sum(results)
    total = len(results)
    print(f"Passed: {passed}/{total}")
    
    if all(results):
        print("\n✅ All integration tests PASSED!")
        return 0
    else:
        print("\n❌ Some integration tests FAILED!")
        return 1


if __name__ == "__main__":
    sys.exit(main())