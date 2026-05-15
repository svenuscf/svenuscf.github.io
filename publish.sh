#!/bin/bash

cp public/index.html .
cp public/index.xml .
cp public/404.html .
cp public/sitemap.xml .

cp -R public/posts/* posts/
cp -R public/tags/* tags/
cp -R public/categories/* categories/」
cp -R public/about/* about/ 2>/dev/null || true
cp -R public/page/* page/ 2>/dev/null || true
