Shader "Custom/Shader_GridSlide_NoGridLines"
{
    Properties
    {
        // _MainTex: The base image to be animated.
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Pass
        {
            CGPROGRAM
            // Vertex and fragment shader entry points.
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            
            // Declare texture sampler.
            sampler2D _MainTex;
            
            // Structure for vertex input.
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            // Structure for data passed to the fragment shader.
            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            // Vertex shader: transforms vertices and passes UVs.
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            // Fragment shader: computes the grid slide effect without drawing grid lines.
            fixed4 frag (v2f i) : SV_Target
            {
                // --- Timing and Cycle ---
                // Full cycle duration: 12 seconds (each phase is 3 seconds).
                float cycleTime = 6.0;
                // Normalize time into a cycle [0,1].
                float t = frac(_Time.y / cycleTime);
                
                // --- Compute Displacement for the Movement Path ---
                // The movement path in UV space is:
                // Phase 1 (0 ≤ t < 0.25): from (0,0) to (-0.5, 0)
                // Phase 2 (0.25 ≤ t < 0.5): from (-0.5, 0) to (-0.5, -0.5)
                // Phase 3 (0.5 ≤ t < 0.75): from (-0.5, -0.5) to (0, -0.5)
                // Phase 4 (0.75 ≤ t < 1.0): from (0, -0.5) back to (0,0)
                float2 d;
                if (t < 0.25)
                {
                    float phase = t / 0.25;
                    d = lerp(float2(0,0), float2(-0.5, 0), phase);
                }
                else if (t < 0.5)
                {
                    float phase = (t - 0.25) / 0.25;
                    d = lerp(float2(-0.5, 0), float2(-0.5, -0.5), phase);
                }
                else if (t < 0.75)
                {
                    float phase = (t - 0.5) / 0.25;
                    d = lerp(float2(-0.5, -0.5), float2(0, -0.5), phase);
                }
                else
                {
                    float phase = (t - 0.75) / 0.25;
                    d = lerp(float2(0, -0.5), float2(0, 0), phase);
                }
                
                // --- Determine Grid Cell and Parity ---
                // Multiply UV by 4 to divide the image into a 4×4 grid.
                float2 gridCoord = i.uv * 4.0;
                float2 cellIndex = floor(gridCoord);
                // Compute parity based on the sum of the cell indices.
                float parity = fmod(cellIndex.x + cellIndex.y, 2.0);
                // In even cells use displacement d; in odd cells use -d.
                float2 disp = (parity < 0.5) ? d : -d;
                
                // --- Compute New Sampling UV ---
                // Apply the displacement to the original UV coordinates.
                float2 newUV = i.uv + disp;
                // Wrap UV coordinates so that the image tiles.
                newUV = frac(newUV);
                
                // Sample the image using the displaced UV coordinates.
                fixed4 col = tex2D(_MainTex, newUV);
                
                // --- Output ---
                // No grid lines are drawn; simply output the displaced image.
                return col;
            }
            ENDCG
        }
    }
    FallBack "Unlit/Texture"
}