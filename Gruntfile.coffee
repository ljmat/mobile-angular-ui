#   CSS workflow:
#
#   2) create a combined css with Bootstrap, Fontawesome and Mobile Angular UI sources
#   3) split mobile css
#      into different files 
#      according to media queries
#    
#   4) copy combined and partials files minified and unminified to dist
#
module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    concurrent:
      devel: 
        tasks: ['connect', 'watch']
        options:
          limit: 2
          logConcurrentOutput: true

      site: 
        tasks: ['connect', 'site-guard']
        options:
          limit: 2
          logConcurrentOutput: true

      all: 
        tasks: ['connect', 'watch', 'site-guard']
        options:
          limit: 3
          logConcurrentOutput: true

    smq: # Split Css by Media Queries
      bootstrap:
        src:  "tmp/mobile.css"
        dest: "dist/css"
        basename: "mobile-angular-ui"

    clean: 
      dev: ["tmp", "dist", "demo/assets"]
      site: ["gh-pages"]
      site_out: ["site/output"]
      tmp_gh_pages_git: ["tmp/gh_pages_git"]

    copy:
      desktop:
        expand: true
        cwd:  "tmp/"
        src:  ["mobile-angular-ui-desktop.css"]
        dest: "dist/css"

      fa:
        expand: true, 
        cwd: "bower_components/font-awesome/fonts", 
        src: ["**"], 
        dest: 'dist/fonts'

      demo:
        expand: true,
        cwd: "dist/"
        src: ["**"],
        dest: "demo/assets"

      demo_angular:
        expand: true,
        cwd: "bower_components/angular"
        src: ["angular.js", "angular.min.js"],
        dest: "demo/assets/js"

      demo_angular_touch:
        expand: true,
        cwd: "bower_components/angular-touch"
        src: ["angular-touch.js", "angular-touch.min.js"],
        dest: "demo/assets/js"

      demo_angular_route:
        expand: true,
        cwd: "bower_components/angular-route"
        src: ["angular-route.js", "angular-route.min.js"],
        dest: "demo/assets/js"

      backup_gh_pages_git:
        expand: true,
        cwd: "gh-pages/.git"
        src: ["**"],
        dest: "tmp/gh_pages_git"
      
      restore_gh_pages_git:
        expand: true,
        cwd: "tmp/gh_pages_git"
        src: ["**"],
        dest: "gh-pages/.git"

      demo_to_site_out:
        expand: true,
        cwd: "demo/"
        src: ["**"],
        dest: "site/output/demo"

      gh_pages_site:
        expand: true,
        cwd: "site/output"
        src: ["**"],
        dest: "gh-pages"

      gh_pages_cname:
        expand: true,
        cwd: "site"
        src: ["CNAME"],
        dest: "gh-pages"


    less:
      dist:
        options:
          paths: ["src/less","bower_components"]

        files:
          "tmp/mobile.css": "src/less/mobile-angular-ui.less"
          "tmp/mobile-angular-ui-desktop.css": "src/less/mobile-angular-ui-desktop.less"

    concat:
      js:
        files:
          "dist/js/mobile-angular-ui.js": [
            "bower_components/overthrow/src/overthrow-detect.js"
            "bower_components/overthrow/src/overthrow-init.js"
            "bower_components/overthrow/src/overthrow-polyfill.js"
            "bower_components/overthrow/src/overthrow-toss.js"
            "bower_components/fastclick/lib/fastclick.js"
            "src/js/lib/*.js"
            "src/js/mobile-angular-ui.js"
          ]

    uglify:
      minify:
        options:
          report: 'min'
        files:
          "dist/js/mobile-angular-ui.min.js": ["dist/js/mobile-angular-ui.js"]

    cssmin:
      minify:
        options:
          report: 'min'
        expand: true
        cwd: 'dist/css/'
        src: ['*.css', '!*.min.css']
        dest: 'dist/css/'
        ext: '.min.css'

    watch:
      all:
        files: "src/**/*"
        tasks: ["build"]
      demo:
        files: "demo/*"
        tasks: ["copy:demo_to_site_out"]

    connect:
      server:
        options:
          hostname: '0.0.0.0'
          port: 3000
          base: 'site/output'
          keepalive: true

    githubPages:
      site:
        options:
          commitMessage: "push"

        src: "gh-pages"

  grunt.loadNpmTasks "grunt-contrib-clean"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-contrib-cssmin"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-github-pages"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-concurrent"

  grunt.task.loadTasks "tasks"

  grunt.registerTask "build", [ "clean:dev"
                                "less"
                                "smq"
                                "concat"
                                "copy:desktop"
                                "copy:fa"
                                "uglify"
                                "cssmin"
                                "copy:demo"
                                "copy:demo_angular"
                                "copy:demo_angular_route"
                                "copy:demo_angular_touch"
                                "copy:demo_to_site_out"
                              ]

  grunt.registerTask "devel",      ["build", "concurrent:devel"]
  grunt.registerTask "devel-site", ["clean:site_out", "build", "concurrent:site"]
  grunt.registerTask "default",    ["clean:site_out", "build", "concurrent:all"]
  
  grunt.registerTask "push-site", [ 
      "copy:backup_gh_pages_git"
      "clean:site"
      "copy:restore_gh_pages_git"
      "clean:tmp_gh_pages_git"
      "copy:gh_pages_site"
      "copy:gh_pages_cname"
      "githubPages:site"
    ]

