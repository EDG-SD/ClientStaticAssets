# ClientStaticAssets
Client Static Asset generation package for .net8 projects.

ported from the blog post:
https://devblogs.microsoft.com/dotnet/build-client-web-assets-for-your-razor-class-library

Typical workflow (for me):

In .net project, make and cd into 'assets' directory.
Run webpack-cli to initialize webpack config: npx webpack init (may take two attempts if not loaded globally)
I typically only choose the 'typescript' and 'css' with post-css options.
Modify the package.json to be build:Debug and build:Release tasks.
Modify the webpack.config.js file to output into '../wwwroot' folder.
Add any additional npm assets: bootstrap or tailwindcss ect...
Make sure npm install has been run once to generate the npm-ci file.

cd back into the root .net project.
dotnet add package ClientStaticAssets.

On build, the build:Debug or build:Release tasks will be run generating the output files to wwwroot.
