import {mkdir,copyFile,cp,rm} from 'node:fs/promises';
await rm('dist',{recursive:true,force:true});await mkdir('dist',{recursive:true});
for(const file of ['index.html','brand.css','app.js','scroll-hero.css','clinic.css','scroll-hero.js','before-after.js','reveal.js']) await copyFile(file,'dist/'+file);
await cp('assets','dist/assets',{recursive:true});
await mkdir('dist/admin',{recursive:true});
await (await import('node:fs/promises')).writeFile('dist/admin/index.html','<!doctype html><meta charset="utf-8"><meta name="robots" content="noindex"><title>Staff sign in</title><script>location.replace("/#admin")</script><a href="/#admin">Staff sign in</a>');
console.log('Static site built in dist/');
