//-----------------------------------------------------------------------
// <copyright file="CardboardStartup.cs" company="Google LLC">
// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>
//-----------------------------------------------------------------------

using Google.XR.Cardboard;
using UnityEngine;
using UnityEngine.XR.Management;
using System.Collections.Generic;

using XRL = UnityEngine.XR.Management.XRLoader;

/// <summary>
/// Initializes Cardboard XR Plugin.
/// </summary>
public class CardboardStartup : MonoBehaviour
{
    XRL m_VRLoader;
    XRL m_ARLoader;
    /// <summary>
    /// Start is called before the first frame update.
    /// </summary>
    public void Start()
    {
        Debug.Log("Initializing XR...");
        XRGeneralSettings.Instance.Manager.InitializeLoader();
        Debug.Log(XRGeneralSettings.Instance.Manager.activeLoaders.Count);
        foreach (var loader in XRGeneralSettings.Instance.Manager.activeLoaders)
        {
            if (loader is Google.XR.Cardboard.XRLoader)
            {
                Debug.Log("Cardboard");
                m_VRLoader = loader;
            }
            else if (loader is XRL)
            {
                Debug.Log("XRL");
                m_ARLoader = loader;
            }
        }
        /* if (m_ARLoader == null || m_VRLoader == null) */
        /* { */
        /*     foreach (var loader in XRGeneralSettings.Instance.Manager.activeLoaders) */
        /*     { */
        /*         if (loader is XRL) */
        /*         { */
        /*             m_ARLoader = loader; */
        /*         } */
        /*         else if (loader is Google.XR.Cardboard.XRLoader) */
        /*         { */
        /*             m_VRLoader = loader; */
        /*         } */
        /*     } */
        /* } */

        /* if (!HasARLoader || !HasVRLoader) */
        /* { */
        /*     Debug.LogError($"Loaders are missing from the list!{(!HasVRLoader ? "\n\tVR Loader Missing" : "")}{(!HasARLoader ? "\n\tAR Loader Missing." : "")}"); */
        /*     enabled = false; */
        /* } */
        if (XRGeneralSettings.Instance.Manager.activeLoader == null)
        {
            Debug.LogError("Initializing XR Failed.");
        }
        else
        {
            Debug.Log("XR initialized.");

            Debug.Log("switching to VR Attempt");
            if(m_VRLoader != null) {
              XRGeneralSettings.Instance.Manager.activeLoader.Stop();
              /* XRGeneralSettings.Instance.Manager.activeLoader.Deinitialize(); */
              m_VRLoader.Initialize();
            }
            else {
              Debug.Log("VR Loader not found");
            }
            Debug.Log("Starting XR...");
            XRGeneralSettings.Instance.Manager.StartSubsystems();
          
            Debug.Log("XR started.");
        }
            Api.ReloadDeviceParams();
        if (Api.HasNewDeviceParams())
        {
            Api.ReloadDeviceParams();
        }

        // Configures the app to not shut down the screen and sets the brightness to maximum.
        // Brightness control is expected to work only in iOS, see:
        // https://docs.unity3d.com/ScriptReference/Screen-brightness.html.
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        Screen.brightness = 1.0f;

        // Checks if the device parameters are stored and scans them if not.
        if (!Api.HasDeviceParams())
        {
            Api.ScanDeviceParams();
        }
    }

    /// <summary>
    /// Update is called once per frame.
    /// </summary>
    public void Update()
    {
        if (Api.IsGearButtonPressed)
        {
            Api.ScanDeviceParams();
        }

        if (Api.IsCloseButtonPressed)
        {
            Application.Quit();
        }

        if (Api.IsTriggerHeldPressed)
        {
            Api.Recenter();
        }

        if (Api.HasNewDeviceParams())
        {
            Api.ReloadDeviceParams();
        }

        Api.UpdateScreenParams();
    }
}
