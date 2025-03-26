Shader "Unlit/DM_03_phong"  //名称和路径
{
    Properties  //属性块
    {
        _MainCol ("颜色",color) = (1.0,1.0,1.0,1.0)
        _SpecularPow ("高光次幂",range(1,90)) = 30
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }  //渲染类型
        LOD 100  //渲染细节层次

        Pass  //方法块
        {
            CGPROGRAM
            #pragma vertex vert  //顶点着色器vert
            #pragma fragment frag  //像素着色器frag

            #include "UnityCG.cginc"  //引入 UnityCG.cginc 文件，该文件包含了许多 Unity 提供的常用函数和宏，方便在着色器中使用
            #include "Lighting.cginc"

            struct appdata  //顶点着色器的输入结构体
            {
                float4 vertex : POSITION;  //顶点位置信息
                float2 uv : TEXCOORD0;  //纹理坐标信息
                float3 normal : NORMAL;  //法线信息
            };

            struct v2f  //顶点着色器函数输出结构体
            {
                float2 uv : TEXCOORD0;  //传递纹理坐标
                float4 posCS : SV_POSITION;  //变换后的位置：裁剪空间中的顶点位置
                float3 nDirWS : TEXCOORD1;   //世界空间的法线方向
                float3 posWS : TEXCOORD2;  //世界空间的顶点位置
            };
            //全局变量声明
            uniform float3 _MainCol;
            uniform float  _SpecularPow;

            v2f vert (appdata v)  //顶点着色器vert
            {
                v2f o;
                o.posCS = UnityObjectToClipPos(v.vertex);  //将顶点从模型空间转换到裁剪空间。
                o.nDirWS = UnityObjectToWorldNormal(v.normal);//将顶点的法线向量从模型空间转换到世界空间
                o.posWS = mul(unity_ObjectToWorld,v.vertex).xyz;//将顶点的位置从模型空间转换到世界空间
                return o;
            }

            fixed4 frag (v2f i) : SV_Target  //像素着色器frag
            {
                //准备向量
                float3 nDir = i.nDirWS;
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 hDir = normalize(vDir + lDir);
                //准备点积结果
                float ndotl = dot(nDir,lDir);
                float ndoth = dot(nDir,hDir);
                //光照模型
                float lambert = max(0.0,ndotl);
                float blinnPhong = pow(max(0.0,ndoth),_SpecularPow);
                float3 finalRGB = _MainCol * lambert + blinnPhong;
                //返回结果
                return fixed4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
}

