#!/bin/sh
body=`cat /dev/stdin`

cwd=`dirname "${0}"`
stylesheets=(github.css highlight.css)
javascripts=(highlight.js)

cat <<EOL
<!doctype html>
<html lang="ja">
<head>
<meta charset="UTF-8">
`for css in $stylesheets; do echo "<style>$(cat "${cwd}/static/${css}")</style>"; done`
`for js in $javascripts; do echo "<script>$(cat "${cwd}/static/${js}")</script>"; done`
</head>
<body>
$body
</body>
</html>
EOL
