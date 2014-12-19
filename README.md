ngx-lua-image-cdn
=================
  剪裁版的Image CDN.
  
  
1。提供普通图片的裁剪，缩略，格式转化，等

http://atest.img.detuyun.cn/demo221.jpg?imageView/w/250/h/187

http://atest.img.detuyun.cn/demo221.jpg?imageView/w/250

http://sample.img.detuyun.cn/sample.jpg?imageview/crop/w_100,h_150,g_south



2.提供FACE++所有的人脸识别服务

http://atest.img.detuyun.cn/demo221.jpg?imageView/4/w/250/h/187&imagetype=imageserver&stype=face&smethod=%2Fdetection%2Fdetect&attribute%3Dglass%2Cpose%2Cgender%2Cage%2Crace%2Csmiling
 >
  {
      "face": [
          {
              "attribute": {
                  "age": {
                      "range": 6, 
                      "value": 20
                  }, 
                  "gender": {
                      "confidence": 99.9999, 
                      "value": "Female"
                  }, 
                  "race": {
                      "confidence": 83.9521, 
                      "value": "Asian"
                  }, 
                  "smiling": {
                      "value": 8.84949
                  }
              }, 
              "face_id": "ea14cd1dc2126cb87682e96535ce5890", 
              "position": {
                  "center": {
                      "x": 50.26738, 
                      "y": 36.363636
                  }, 
                  "eye_left": {
                      "x": 43.144171, 
                      "y": 30.449786
                  }, 
                  "eye_right": {
                      "x": 56.645989, 
                      "y": 30.68984
                  }, 
                  "height": 27.807487, 
                  "mouth_left": {
                      "x": 45.545348, 
                      "y": 44.784225
                  }, 
                  "mouth_right": {
                      "x": 54.942781, 
                      "y": 44.476257
                  }, 
                  "nose": {
                      "x": 50.039144, 
                      "y": 38.038556
                  }, 
                  "width": 27.807487
              }, 
              "tag": ""
          }
      ], 
      "img_height": 187, 
      "img_id": "1fb6bad7e0d34297a69b41a0bb8cbcf9", 
      "img_width": 187, 
      "session_id": "47033a00e9f248f8a8a1c33ee45efb93", 
      "url": "http://atest.img.detuyun.cn/demo221.jpg?imageView/4/w/250/h/187"
  }


1。提供物品TAG服务
http://atest.img.detuyun.cn/demo221.jpg?imageview&imagetype=imageserver&stype=rekogni&smethod=scene_understanding_3

