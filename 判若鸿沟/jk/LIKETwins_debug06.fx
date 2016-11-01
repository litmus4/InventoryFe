///////////////////////////////////////////////////
//       Vars
///////////////////////////////////////////////////

float4x4 matWorldViewProj : WVP;
float4x4 matNorm : W;
float4x4 matDir : WD;

float3 lightDir : LDIRECTION;
float4 lightAmb : LAMBIENT;
float4 lightDiff : LDIFFUSE;
float4 lightSpec : LSPECULAR;

float intenAmb : IAMBIENT;
float intenDiff : IDIFFUSE;
float intenSpec : ISPECULAR;
float intenEmi : IEMISSIVE;

float4 materAmb : KAMBIENT;
float4 materDiff : KDIFFUSE;
float4 materSpec : KSPECULAR;
float4 materEmi : KEMISSIVE;

float exSpec : ESPECULAR;
float3 eye : EYE;

///////////////////////////////////////////////////
//       Vertex Shader
///////////////////////////////////////////////////

struct VS_INPUT 
{
   float3 position : POSITION;
   float3 normal : NORMAL;
   float2 texcoo : TEXCOORD0;
};

struct VS_OUTPUT 
{
   float4 position : POSITION;
   float2 texcoo : TEXCOORD0;
   float3 N : TEXCOORD1;
   float3 L : TEXCOORD2;
   float3 V : TEXCOORD3;
   //float3 H : TEXCOORD4;
};

VS_OUTPUT vs_main(VS_INPUT Input)
{
   VS_OUTPUT Output;

   Output.position=mul(float4(Input.position.xyz,1.0f),matWorldViewProj);
   Output.texcoo=Input.texcoo;
   
   Output.N=normalize(mul(Input.normal,(float3x3)matNorm));
   Output.L=normalize(mul(-lightDir,(float3x3)matDir));
   float3 posNorm=mul(float4(Input.position.xyz,1.0f),matNorm);
   Output.V=normalize(eye-posNorm);
   //Output.H=normalize(Output.L+Output.V);
   
   return Output;
}

///////////////////////////////////////////////////
//       Pixel Shader
///////////////////////////////////////////////////

texture tex : TEX;

sampler samp=sampler_state
{
   Texture=<tex>;
   AddressU=WRAP;
   AddressV=WRAP;
   MipFilter=LINEAR;
   MinFilter=LINEAR;
   MagFilter=LINEAR;
};

struct PS_INPUT
{
   float2 texcoo : TEXCOORD0;
   float3 N : TEXCOORD1;
   float3 L : TEXCOORD2;
   float3 V : TEXCOORD3;
   //float3 H : TEXCOORD4;
};

float4 ps_main(PS_INPUT Input) : COLOR
{
   float3 R=2*dot(Input.N,Input.L)*Input.N-Input.L;//»»HÊ±×¢ÊÍµô
   
   float4 ambColor=intenAmb*materAmb*lightAmb;
   float4 diffColor=intenDiff*materDiff*lightDiff*max(0,dot(Input.N,Input.L));
   int isNotPass=dot(Input.N,Input.L)>0?1:0;
   int isNotOver=dot(Input.N,Input.V)>0?1:0;
   float4 specColor=intenSpec*materSpec*lightSpec*pow(max(0.00001f,dot(R,Input.V)),exSpec)*isNotPass*isNotOver;//»»HÊ±×¢ÊÍµô
   //float4 specColor=intenSpec*materSpec*lightSpec*pow(max(0.00001f,dot(Input.N,Input.H)),exSpec)*isNotPass*isNotOver;
   float4 emiColor=intenEmi*materEmi;
   float4 ambdiffTex=tex2D(samp,Input.texcoo);
   
   return (ambColor+diffColor)*ambdiffTex+specColor+emiColor;
}

///////////////////////////////////////////////////
//       Techniques
///////////////////////////////////////////////////

technique tec0
{
   pass p0
   {
      VertexShader=compile vs_3_0 vs_main();
      PixelShader=compile ps_3_0 ps_main();
   }
}