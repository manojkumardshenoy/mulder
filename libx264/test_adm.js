//AD  <- Needed to identify//
//--automatically built--

var app = new Avidemux();

//** Video **
app.load("F:/Samples/Lossless/foreman_cif.352x288.avi");
app.append("F:/Samples/Lossless/bus_cif.352x288.avi");
app.append("F:/Samples/Lossless/football_cif.352x288.avi");
app.append("F:/Samples/Lossless/silent_cif.352x288.avi");
app.append("F:/Samples/Lossless/stefan_cif.352x288.avi");
app.append("F:/Samples/Lossless/paris_cif.352x288.avi");

/*
app.append("F:/Samples/Lossless/firebelly.352x288.avi");
*/

//** Postproc **
app.video.setPostProc(0,0,0);
app.video.fps1000 = 30000;

//** Filters **

//** Video Codec conf **
app.video.codecPlugin("32BCB447-21C9-4210-AE9A-4FCE6C8588AE", "x264", "AQ=20", "<?xml version='1.0'?><x264Config><x264Options><threads>0</threads><deterministic>true</deterministic><threadedLookahead>-1</threadedLookahead><idcLevel>-1</idcLevel><vui><sarAsInput>false</sarAsInput><sarHeight>1</sarHeight><sarWidth>1</sarWidth><overscan>undefined</overscan><videoFormat>undefined</videoFormat><fullRangeSamples>false</fullRangeSamples><colorPrimaries>undefined</colorPrimaries><transfer>undefined</transfer><colorMatrix>undefined</colorMatrix><chromaSampleLocation>0</chromaSampleLocation></vui><referenceFrames>8</referenceFrames><gopMaximumSize>750</gopMaximumSize><gopMinimumSize>25</gopMinimumSize><scenecutThreshold>40</scenecutThreshold><bFrames>16</bFrames><adaptiveBframeDecision>2</adaptiveBframeDecision><bFrameBias>0</bFrameBias><bFrameReferences>normal</bFrameReferences><loopFilter>true</loopFilter><loopFilterAlphaC0>-1</loopFilterAlphaC0><loopFilterBeta>-1</loopFilterBeta><cabac>true</cabac><interlaced>false</interlaced><constrainedIntraPrediction>false</constrainedIntraPrediction><cqmPreset>flat</cqmPreset><intra4x4Luma><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value></intra4x4Luma><intraChroma><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value></intraChroma><inter4x4Luma><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value></inter4x4Luma><interChroma><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value></interChroma><intra8x8Luma><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value></intra8x8Luma><inter8x8Luma><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value><value>16</value></inter8x8Luma><analyse><partitionI4x4>true</partitionI4x4><partitionI8x8>true</partitionI8x8><partitionP8x8>true</partitionP8x8><partitionP4x4>true</partitionP4x4><partitionB8x8>true</partitionB8x8><dct8x8>true</dct8x8><weightedPredictionPframes>smart</weightedPredictionPframes><weightedPrediction>true</weightedPrediction><directPredictionMode>auto</directPredictionMode><chromaLumaQuantiserDifference>0</chromaLumaQuantiserDifference><motionEstimationMethod>multi-hexagonal</motionEstimationMethod><motionVectorSearchRange>24</motionVectorSearchRange><motionVectorLength>-1</motionVectorLength><motionVectorThreadBuffer>-1</motionVectorThreadBuffer><subpixelRefinement>9</subpixelRefinement><chromaMotionEstimation>true</chromaMotionEstimation><mixedReferences>true</mixedReferences><trellis>allModeDecisions</trellis><fastPSkip>true</fastPSkip><dctDecimate>true</dctDecimate><psychoRdo>1</psychoRdo><noiseReduction>0</noiseReduction><interLumaDeadzone>21</interLumaDeadzone><intraLumaDeadzone>11</intraLumaDeadzone></analyse><rateControl><quantiserMinimum>10</quantiserMinimum><quantiserMaximum>51</quantiserMaximum><quantiserStep>4</quantiserStep><averageBitrateTolerance>1</averageBitrateTolerance><vbvMaximumBitrate>0</vbvMaximumBitrate><vbvBufferSize>0</vbvBufferSize><vbvInitialOccupancy>0.9</vbvInitialOccupancy><ipFrameQuantiser>1.4</ipFrameQuantiser><pbFrameQuantiser>1.3</pbFrameQuantiser><adaptiveQuantiserMode>variance</adaptiveQuantiserMode><adaptiveQuantiserStrength>1</adaptiveQuantiserStrength><mbTree>true</mbTree><frametypeLookahead>60</frametypeLookahead><quantiserCurveCompression>0.6</quantiserCurveCompression><reduceFluxBeforeCurveCompression>20</reduceFluxBeforeCurveCompression><reduceFluxAfterCurveCompression>0.5</reduceFluxAfterCurveCompression></rateControl><accessUnitDelimiters>false</accessUnitDelimiters><spsIdentifier>0</spsIdentifier><sliceMaxSize>0</sliceMaxSize><sliceMaxMacroblocks>0</sliceMaxMacroblocks><sliceCount>0</sliceCount></x264Options></x264Config>");

//** Audio **
app.audio.reset();
app.audio.codec("Lame",128,20,"80 00 00 00 00 00 00 00 02 00 00 00 02 00 00 00 00 00 00 00 ");
app.audio.normalizeMode=0;
app.audio.normalizeValue=0;
app.audio.delay=0;
app.audio.mixer="NONE";
app.setContainer("AVI");
//setSuccess(app.save("C:/Temp/test.avi"));
//app.Exit();

//End of script
