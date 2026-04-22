Duplicate TWO of the THREE shaders from the TOP ROW seen here.

THE BOTTOM ROW IS JUST FOR EXAMPLE/DISCUSSION.

If you choose to do all three on the top row, you can receive up to 30% extra credit!

Start by creating a Shader->Unlit Shader in your project. Then create a Material and drag the Shader onto it.  Add an image to your project and then drag it onto the Shader into the 

Next put a GameObject->3D Object->Plane onto the scene and apply the new material to it. Move the camera over the plane and check that your image appears when you run the project.

Edit the shader in Visual Studio, focusing on the "fixed4 frag(v2f i)" function.

Repeat for your second shader.  Don't forget to put detailed comments on each line!

Remember that shaders are internally stateless, to access external state you will need to use built-in variables available from Unity. [https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html]

Congrats, you've written code that's running on the GPU!

It is required to turn in both video of your shaders operating, as linked above, and the two .shader files themselves.

Specifics on the effects:

Snow and roll: The roll timing is irrelevant, but the noise should look similar. Make sure the noise is not lost against light or dark areas.
Swirl and fade: There should be two images and the fade between them should occur at maximum swirl so that each image becomes visible in the middle of the cycle. It should be slow enough to make out the image when it becomes visible.
Grid slide: Each grid should move as it does in the example, in four phases, coming together at the end of the fourth phase.

NOTE: You can pick your own textures!
