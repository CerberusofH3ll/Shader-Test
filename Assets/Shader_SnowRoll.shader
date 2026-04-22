Shader "Custom/Shader_SnowRoll"
{
    // Define shader properties that appear in the Material Inspector.
    Properties
    {
        // _MainTex: The main texture used by this shader.
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // Tags help Unity determine rendering settings.
        Tags { "RenderType"="Opaque" }
        // Level of Detail (LOD) for the shader.
        LOD 100

        Pass
        {
            // Begin the programmable shader block.
            CGPROGRAM
            // Declare the entry points for vertex and fragment shaders.
            #pragma vertex vert
            #pragma fragment frag

            // Include common Unity shader functions and macros.
            #include "UnityCG.cginc"

            // Declare the main texture sampler.
            sampler2D _MainTex;

            // Structure for vertex input data.
            struct appdata
            {
                float4 vertex : POSITION;  // Vertex position in object space.
                float2 uv : TEXCOORD0;       // Texture coordinates for the vertex.
            };

            // Structure for data passed from the vertex shader to the fragment shader.
            struct v2f
            {
                float2 uv : TEXCOORD0;       // Interpolated texture coordinates.
                float4 vertex : SV_POSITION; // Transformed vertex position in clip space.
            };

            // Vertex shader: Transforms vertices from object space to clip space.
            v2f vert (appdata v)
            {
                v2f o; // Create output structure instance.
                o.vertex = UnityObjectToClipPos(v.vertex); // Transform vertex position.
                o.uv = v.uv; // Pass the original texture coordinates.
                return o;
            }

            // A simple pseudo-random noise function.
            // This function takes a 2D vector 'p' and returns a value between 0 and 1.
            float noise(float2 p)
            {
                return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
            }

            // Fragment shader: Applies upward movement and overlays white static noise.
            fixed4 frag (v2f i) : SV_Target
            {
                // --- Upward Movement and UV Distortion ---

                // Start with the original UV coordinates.
                float2 uv = i.uv;

                // Move the image upward over time by offsetting the y-coordinate.
                // _Time.y is a built-in Unity variable that increases over time.
                uv.y -= _Time.y;

                // Calculate noise to apply a slight distortion.
                float noiseInputScale = 10.0;
                float n = noise(uv * noiseInputScale + _Time.y);

                // Apply a subtle UV distortion using the noise value.
                // Reducing noiseAmplitude to minimize the distortion effect.
                float noiseAmplitude = 0.01;
                uv.x += (n - 0.5) * noiseAmplitude;
                uv.y += (n - 0.5) * noiseAmplitude;

                // Sample the main texture using the modified UV coordinates.
                fixed4 color = tex2D(_MainTex, uv);

                // --- White Static Noise Overlay ---

                // Generate a noise value for the static effect using the original UV coordinates.
                // Multiplying _Time.y by 2.0 increases the flicker rate.
                float staticNoiseValue = noise(i.uv * noiseInputScale + _Time.y * 2.0);

                // Use a step function to create a binary noise value.
                // This produces 0 or 1, mimicking white static (white pixels where the noise is high).
                float threshold = 0.5;
                float whiteStatic = step(threshold, staticNoiseValue);

                // Create a white noise color: white (1) where static is active, black (0) otherwise.
                fixed4 noiseColor = fixed4(whiteStatic, whiteStatic, whiteStatic, 1.0);

                // Blend the main texture with the white static overlay.
                // blendFactor controls the intensity of the static noise.
                float blendFactor = 0.3;
                fixed4 finalColor = lerp(color, noiseColor, blendFactor);

                // Return the final color for this pixel.
                return finalColor;
            }
            // End the shader program block.
            ENDCG
        }
    }
    // Fallback: Use a basic Unlit texture shader if this shader is unsupported.
    FallBack "Unlit/Texture"
}