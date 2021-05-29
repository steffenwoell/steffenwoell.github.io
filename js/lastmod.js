<script type='text/javascript'>

function showFileModified() {
        var input, file;

        // Testing for 'function' is more specific and correct, but doesn't work with Safari 6.x
        if (typeof window.FileReader !== 'function' &&
            typeof window.FileReader !== 'object') {
            write("The file API isn't supported on this browser yet.");
            return;
        }

        input = document.getElementById('filename');
        if (!input) {
            write("Um, couldn't find the filename element.");
        }
        else if (!input.files) {
            write("This browser doesn't seem to support the `files` property of file inputs.");
        }
        else if (!input.files[0]) {
            write("Please select a file before clicking 'Show Modified'");
        }
        else {
            file = input.files[0];
            write("The last modified date of file '" + file.name + "' is " + new Date(file.lastModified));
        }

        function write(msg) {
            var p = document.createElement('p');
            p.innerHTML = msg;
            document.body.appendChild(p);
        }
    }

    </script>
