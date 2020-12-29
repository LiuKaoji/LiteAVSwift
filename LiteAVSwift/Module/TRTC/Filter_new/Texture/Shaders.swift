class Shaders {
    
    static let processVertex =
    """
     attribute vec4 position;
     attribute vec4 inputTextureCoordinate;
     
     varying vec2 textureCoordinate;

    void main()
    {
        gl_Position = position;
        textureCoordinate = inputTextureCoordinate.xy;
    }
    """

    static let processFragement =
    """
     varying highp vec2 textureCoordinate;
     
     uniform sampler2D inputImageTexture;

     void main()
     {
         lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
         
         gl_FragColor = vec4((1.0 - textureColor.rgb), textureColor.w);
     }
    """
}



