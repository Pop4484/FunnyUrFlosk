﻿using UnityEngine;

/// <summary>
/// Utility behaviour for gyrating any dogs that appear onscreen. Can be used with non-dog objects, but not recommended.
/// </summary>
public class DogSpeen : MonoBehaviour {
    private RectTransform dog;
    private void Start()  { dog = GetComponent<RectTransform>(); }
    private void Update() { dog.Rotate(Vector3.forward * 360 * Time.deltaTime); }
}
