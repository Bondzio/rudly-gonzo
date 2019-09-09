file.openAsync(Windows.Storage.FileAccessMode.readWrite).then(function (_stream) {
        stream = _stream;

        var encoderId;
        switch (fileType) {
            case ".jpg":
                encoderId = Windows.Graphics.Imaging.BitmapEncoder.jpegEncoderId;
                break;
        }
        return Windows.Graphics.Imaging.BitmapEncoder.createAsync(encoderId, stream);
        }).then(function (encoder) {

              // Your code here.
        }