import {mkdir,copyFile,cp,rm} from 'node:fs/promises';
await rm('dist',{recursive:true,force:true});await mkdir('dist',{recursive:true});
for(const file of ['index.html','brand.css','app.js','scroll-hero.css','clinic.css','scroll-hero.js','before-after.js']) await copyFile(file,'dist/'+file);
await cp('assets','dist/assets',{recursive:true});
console.log('Static site built in dist/');
