FFVideoSource("F:\Samples\Lossless\soccer.704x576.60fps.avi")
AssumeFrameBased()
Dissolve(Last.Trim(0,199), Last.Trim(200,399), Last.Trim(400,599), 15)
