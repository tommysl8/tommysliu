# Tiny static file server for local preview (no Node required).
# Mirrors Vercel's cleanUrls behaviour: /page -> /page.html, and serves 404.html for misses.
# Dev-only helper: POST /__upload?name=<file> saves the request body under img/ (used to pull
# gallery photos through the preview browser when a CDN refuses non-browser downloads).
param(
  [int]$Port = 5500,
  [string]$Root = (Split-Path $PSScriptRoot -Parent)
)

$Root = [System.IO.Path]::GetFullPath($Root)
$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'application/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.webp' = 'image/webp'
  '.gif'  = 'image/gif'
  '.ico'  = 'image/x-icon'
  '.pdf'  = 'application/pdf'
  '.txt'  = 'text/plain; charset=utf-8'
  '.woff' = 'font/woff'
  '.woff2'= 'font/woff2'
  '.mp4'  = 'video/mp4'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Serving $Root at http://localhost:$Port/"

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $res = $ctx.Response
  try {
    $path = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)

    if ($ctx.Request.HttpMethod -eq 'POST' -and $path -eq '/__upload') {
      $name = [string]$ctx.Request.QueryString['name']
      if ($name -match '^[A-Za-z0-9_.-]+$') {
        $dir = Join-Path $Root 'img'
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
        $ms = New-Object System.IO.MemoryStream
        $ctx.Request.InputStream.CopyTo($ms)
        [System.IO.File]::WriteAllBytes((Join-Path $dir $name), $ms.ToArray())
        $res.ContentType = 'text/plain; charset=utf-8'
        $bytes = [System.Text.Encoding]::UTF8.GetBytes("saved $name ($($ms.Length) bytes)")
      } else {
        $res.StatusCode = 400
        $res.ContentType = 'text/plain; charset=utf-8'
        $bytes = [System.Text.Encoding]::UTF8.GetBytes('bad name')
      }
    } else {
      if ($path.EndsWith('/')) { $path += 'index.html' }
      $rel = $path.TrimStart('/') -replace '/', '\'
      $file = Join-Path $Root $rel
      if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        if (Test-Path -LiteralPath "$file.html" -PathType Leaf) { $file = "$file.html" }
        elseif (Test-Path -LiteralPath (Join-Path $file 'index.html') -PathType Leaf) { $file = Join-Path $file 'index.html' }
      }
      $full = [System.IO.Path]::GetFullPath($file)
      if (-not $full.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $full -PathType Leaf)) {
        $res.StatusCode = 404
        $nf = Join-Path $Root '404.html'
        if (Test-Path -LiteralPath $nf -PathType Leaf) {
          $res.ContentType = 'text/html; charset=utf-8'
          $bytes = [System.IO.File]::ReadAllBytes($nf)
        } else {
          $res.ContentType = 'text/plain; charset=utf-8'
          $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
        }
      } else {
        $ext = [System.IO.Path]::GetExtension($full).ToLowerInvariant()
        if ($mime.ContainsKey($ext)) { $res.ContentType = $mime[$ext] } else { $res.ContentType = 'application/octet-stream' }
        $bytes = [System.IO.File]::ReadAllBytes($full)
      }
    }

    $res.Headers['Cache-Control'] = 'no-store'
    $res.ContentLength64 = $bytes.Length
    $res.OutputStream.Write($bytes, 0, $bytes.Length)
  } catch {
    try { $res.StatusCode = 500 } catch {}
  } finally {
    try { $res.OutputStream.Close() } catch {}
  }
}
