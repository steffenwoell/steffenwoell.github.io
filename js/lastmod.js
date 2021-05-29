function get()
    {
        var myObject, f, date;
        myObject = new ActiveXObject("Scripting.FileSystemObject");
        f = myObject.GetFile("c:\\test.txt");
        date = f.DateLastModified;
        alert ("The date this file was last modified is: " + date);
    }
