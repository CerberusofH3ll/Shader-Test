Shader "Custom/Shader_RadialSwirlFade_FadeCompleteAtMax"
{
    Properties
    {
        // _MainTex: Texture A (used predominantly in Phases 1 and 4)
        _MainTex ("Texture A", 2D) = "white" {}
        // _SecondTex: Texture B (used predominantly in Phases 2 and 3)
        _SecondTex ("Texture B", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            // Define the vertex and fragment shader entry points.
            #pragma vertex vert
            #pragma fragment frag
            
            // Include Unity's common shader functions.
            #include "UnityCG.cginc"
            
            // Declare texture samplers.
            sampler2D _MainTex;
            sampler2D _SecondTex;
            
            // Structure for vertex input data.
            struct appdata {
                float4 vertex : POSITION; // Vertex position.
                float2 uv : TEXCOORD0;      // Texture coordinates.
            };
            
            // Structure for data passed from the vertex shader to the fragment shader.
            struct v2f {
                float2 uv : TEXCOORD0;      // Interpolated texture coordinates.
                float4 vertex : SV_POSITION; // Transformed vertex position.
            };
            
            // Vertex shader: transforms vertex positions and passes along UVs.
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            // Fragment shader: applies a radial swirl and smoothly fades between textures.
            fixed4 frag (v2f i) : SV_Target
            {
                // --- Parameters ---
                // Set speed so that each quarter phase lasts 3 seconds (full cycle = 12 seconds).
                float speed = 1.0 / 12.0;
                float maxAngle = 8.0;              // Maximum swirl angle (in radians).
                float2 center = float2(0.5, 0.5);    // Center of the UV space.
                float radiusFalloff = 1.0;         // Radius at which the swirl effect fades.
                
                // --- Time Normalization ---
                // Normalize time into a cycle (p) between 0 and 1.
                float p = frac(_Time.y * speed);
                
                // --- Determine the Current Swirl Angle ---
                float angle = 0.0;
                if (p < 0.25)
                {
                    // Phase 1: p in [0, 0.25]
                    // Swirl rotates clockwise from 0 to -maxAngle.
                    float t = p / 0.25; // t: 0 to 1.
                    angle = lerp(0.0, -maxAngle, t);
                }
                else if (p < 0.5)
                {
                    // Phase 2: p in [0.25, 0.5]
                    // Undo swirl: rotate back from -maxAngle to 0.
                    float t = (p - 0.25) / 0.25;
                    angle = lerp(-maxAngle, 0.0, t);
                }
                else if (p < 0.75)
                {
                    // Phase 3: p in [0.5, 0.75]
                    // Swirl rotates counterclockwise from 0 to +maxAngle.
                    float t = (p - 0.5) / 0.25;
                    angle = lerp(0.0, maxAngle, t);
                }
                else
                {
                    // Phase 4: p in [0.75, 1.0]
                    // Undo swirl: rotate back from +maxAngle to 0.
                    float t = (p - 0.75) / 0.25;
                    angle = lerp(maxAngle, 0.0, t);
                }
                
                // --- Compute the Blend Factor ---
                // The blend factor (b) determines which texture is visible:
                // b = 1  => fully Texture A; b = 0 => fully Texture B.
                float b = 1.0;
                if (p < 0.25)
                {
                    // Phase 1: Fade from Texture A to Texture B.
                    // At p=0, b = 1 (fully A); at p=0.25 (maximum swirl), b = 0 (fully B).
                    b = 1.0 - (p / 0.25);
                }
                else if (p < 0.5)
                {
                    // Phase 2: Hold Texture B.
                    b = 0.0;
                }
                else if (p < 0.75)
                {
                    // Phase 3: Fade from Texture B to Texture A.
                    // At p=0.5, b = 0; at p=0.75 (maximum swirl), b = 1.
                    b = (p - 0.5) / 0.25;
                }
                else
                {
                    // Phase 4: Hold Texture A.
                    b = 1.0;
                }
                
                // --- Apply the Radial Swirl ---
                float2 uv = i.uv;
                float2 diff = uv - center;   // Vector from the center.
                float radius = length(diff);   // Distance from the center.
                // Compute radial factor: full swirl at center, diminishing toward edges.
                float radialFactor = 1.0 - saturate(radius / radiusFalloff);
                // Compute per-pixel rotation.
                float theta = angle * radialFactor;
                float s = sin(theta);
                float c = cos(theta);
                float2 rotatedDiff;
                rotatedDiff.x = diff.x * c - diff.y * s;
                rotatedDiff.y = diff.x * s + diff.y * c;
                float2 swirledUV = center + rotatedDiff;
                
                // --- Sample Both Textures Using the Swirled UV Coordinates ---
                fixed4 colA = tex2D(_MainTex, swirledUV);    // Texture A
                fixed4 colB = tex2D(_SecondTex, swirledUV);    // Texture B
                
                // --- Blend the Two Textures ---
                // When b = 1, output is Texture A; when b = 0, output is Texture B.
                fixed4 finalColor = lerp(colB, colA, b);
                
                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Unlit/Texture"
}