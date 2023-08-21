function[predictOutputSizes,predictOutputTypes,activationSizes,activationTypes]=getNetworkSizeInfo(...
    block,...
    networkToLoad,...
    inputSizes,...
    inputTypes,...
    resizeInput,...
    predictEnabled,...
    inputFormats,...
    activationLayers)
    networkInfo=deep.blocks.internal.getNetworkInfo(block,networkToLoad);
    [predictOutputSizes,predictOutputTypes,activationSizes,activationTypes]=networkInfo.getSizeInfo(...
    inputSizes,inputTypes,resizeInput,predictEnabled,inputFormats,activationLayers);

end
