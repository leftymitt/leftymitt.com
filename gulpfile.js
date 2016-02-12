/*
 * an effective gulpfile.
 */ 

// initialize gulp task variables. 
var gulp = require('gulp'), 
    less = require('gulp-less'),
    concat = require('gulp-concat'),
    cssmin = require('gulp-cssmin'),
    htmlmin = require('gulp-htmlmin'),
    imagemin = require('gulp-imagemin'),
    uglify = require('gulp-uglify'),
    autoprefixer = require('gulp-autoprefixer'),
    flatten = require('gulp-flatten'),
    util = require('gulp-util'),
    run = require('gulp-run'),
    run_sequence = require('run-sequence'),
    rename = require('gulp-rename'),
    changed = require('gulp-changed'),
//    git = require('gulp-git'),
//    gh_pages = require('gulp-gh-pages'),
    watch = require('gulp-watch'),
    browser_sync = require('browser-sync').create(),
    child_process = require('child_process'),
    event_stream = require('event-stream');

// paths for bower components
var bower = {
	uikit: {
		less: './bower_components/uikit/less/',
		js: './bower_components/uikit/js/',
		scss: './bower_components/uikit/scss/',
		fonts: './bower_components/uikit/fonts/'
	},
	jquery: {
		js: './bower_components/jquery/dist/'
	},
	snap: {
		js: './bower_components/Snap.svg/dist/'
	}
}

// paths for source components
var src = {
	uikit: {
		less: './assets/src/less/uikit/',
		js: './assets/src/js/uikit/',
		scss: './assets/src/scss/uikit/',
		fonts:'./assets/src/fonts/uikit/'
	},
	jquery: {
		js: './assets/src/js/jquery/'
	},
	snap: {
		js: './assets/src/js/snap.svg/'
	},
	css: './assets/src/css/',
	less: './assets/src/less/',
	js: './assets/src/js/',
	scss: './assets/src/scss/',
	fonts:'./assets/src/fonts/',
	img:'./assets/src/img/'
}

// paths for final build components
var build = {
	css: './assets/build/css/',
	js: './assets/build/js/',
	fonts:'./assets/build/fonts/',
	img: './assets/build/img/'
}

// uikit source files, exclude as needed
var uikit = {
	core: [ 
		src.uikit.js + 'core/core.js',
		src.uikit.js + 'core/alert.js', 
		src.uikit.js + 'core/button.js', 
		src.uikit.js + 'core/cover.js', 
		src.uikit.js + 'core/dropdown.js', 
		src.uikit.js + 'core/grid.js', 
		src.uikit.js + 'core/modal.js', 
		src.uikit.js + 'core/nav.js', 
		src.uikit.js + 'core/offcanvas.js', 
		src.uikit.js + 'core/scrollspy.js', 
		src.uikit.js + 'core/smooth-scroll.js', 
		src.uikit.js + 'core/switcher.js', 
		src.uikit.js + 'core/tab.js', 
		src.uikit.js + 'core/toggle.js', 
		src.uikit.js + 'core/touch.js', 
		src.uikit.js + 'core/utility.js' 
	],
	components: [ 
		src.uikit.js + 'components/accordion.js',
//		src.uikit.js + 'components/autocomplete.js',
//		src.uikit.js + 'components/datepicker.js',
//		src.uikit.js + 'components/form-password.js',
//		src.uikit.js + 'components/form-select.js',
		src.uikit.js + 'components/grid.js',
//		src.uikit.js + 'components/htmleditor.js',
		src.uikit.js + 'components/lightbox.js',
//		src.uikit.js + 'components/nestable.js',
		src.uikit.js + 'components/notify.js',
		src.uikit.js + 'components/pagination.js',
		src.uikit.js + 'components/parallax.js',
		src.uikit.js + 'components/search.js',
		src.uikit.js + 'components/slider.js',
		src.uikit.js + 'components/slideset.js',
		src.uikit.js + 'components/slideshow.js',
		src.uikit.js + 'components/slideshow-fx.js',
//		src.uikit.js + 'components/sortable.js',
		src.uikit.js + 'components/sticky.js'
//		src.uikit.js + 'components/timepicker.js',
//		src.uikit.js + 'components/tooltip.js',
//		src.uikit.js + 'components/upload.js' 
	]
}

// runs whenever running: $ gulp 
gulp.task('default', ['serve'], function() {
	gulp.start('watch');
});

// install required bower, ruby, and node dependencies.
gulp.task('install', function() {
	run('bundle install').exec();
	run('npm install').exec();
	run('bower install').exec();
});

// update bower, ruby, and node dependencies.
gulp.task('update', function() {
	run('bundle update').exec();
	run('npm update').exec();
	run('bower update').exec();
});

// copy bower components into assets/src. 
//   if you ever mess with stuff in the destinations and need to revert, you
//   should disable the changed() part of the pipe and stop watch(). 
gulp.task('copy', function() {
	gulp.src(bower.uikit.less + '**/*')
		.pipe(changed(src.uikit.less))
		.pipe(gulp.dest(src.uikit.less))
		.on('end', function() { util.log("copied uikit less files."); });

	gulp.src(bower.uikit.scss + '**/*')
		.pipe(changed(src.uikit.scss))
		.pipe(gulp.dest(src.uikit.scss))
		.on('end', function() { util.log("copied uikit scss files."); });
	
	gulp.src([bower.uikit.js + '**/*.js', '!' + bower.uikit.js + '**/*min.js'])
		.pipe(changed(src.uikit.js))
		.pipe(gulp.dest(src.uikit.js))
		.on('end', function() { util.log("copied uikit js files."); });

	gulp.src(bower.uikit.fonts + '**/*')
		.pipe(changed(src.uikit.fonts))
		.pipe(gulp.dest(src.uikit.fonts))
		.on('end', function() { util.log("copied uikit less files."); });
	
	gulp.src([bower.jquery.js + '*.js', '!' + bower.jquery.js + '*.min.js'])
		.pipe(changed(src.jquery.js))
		.pipe(gulp.dest(src.jquery.js))
		.on('end', function() { util.log("copied jquery js files."); });
	
	gulp.src([bower.snap.js + '*.js', '!' + bower.snap.js + '*-min.js'])
		.pipe(changed(src.snap.js))
		.pipe(gulp.dest(src.snap.js))
		.on('end', function() { util.log("copied Snap.svg js files."); });
});

// rebuild all files in assets/build
gulp.task('rebuild', function() {
	run_sequence('build-less', 
	             ['build-css', 'build-js', 'build-fonts', 'build-img'], 
	             'build-html');
});

// build css from less files
//gulp.task('build-css', function() {
gulp.task('build-less', function() {
	return gulp.src(src.less + '*.less')
		.pipe(less())
		.pipe(autoprefixer())
		.pipe(gulp.dest(src.css))
//		.pipe(cssmin())
//		.pipe(rename(function (name) {
//			name.extname = '.min.css';
//		}))
//		.pipe(changed(src.css))
//		.pipe(gulp.dest(build.css));
});

gulp.task('build-css', function() {
	return gulp.src(src.css + '*.css')
		.pipe(concat('uikit.css'))
		.pipe(cssmin())
		.pipe(rename('uikit.min.css'))
		.pipe(gulp.dest(build.css));
});

// compile all js files into one and compress it
gulp.task('build-js', function() {
	gulp.src(src.js + 'jquery/*.js')
		.pipe(concat('jquery.js'), { newLine: '\n;' })
		.pipe(gulp.dest(src.js))
		.pipe(uglify())
		.pipe(rename('jquery.min.js'))
		.pipe(changed(build.js))
		.pipe(gulp.dest(build.js));

	gulp.src(src.js + 'snap.svg/*.js')
		.pipe(concat('snap.svg.js'), { newLine: '\n;' })
		.pipe(gulp.dest(src.js))
		.pipe(uglify())
		.pipe(rename('snap.svg.min.js'))
		.pipe(changed(build.js))
		.pipe(gulp.dest(build.js));

//		gulp.src(uikit.core)
//			.pipe(concat('uikit.js'), { newLine: '\n;' })
//			.pipe(gulp.dest(src.js))
//			.pipe(uglify())
//			.pipe(rename('uikit.min.js'))
//			.pipe(gulp.dest(build.js));

//		gulp.src(uikit.components)
//			.pipe(concat('uk-components.js'), { newLine: '\n;' })
//			.pipe(gulp.dest(src.js))
//			.pipe(uglify())
//			.pipe(rename('uk-components.min.js'))
//			.pipe(gulp.dest(build.js));

	var jquery_stream = gulp.src(src.js + 'jquery/*.js');
	var ukcore_stream = gulp.src(uikit.core);
	var ukcomponents_stream = gulp.src(uikit.components);

//	event_stream.merge(jquery_stream, ukcore_stream, ukcomponents_stream)
	return event_stream.merge(ukcore_stream, ukcomponents_stream)
		.pipe(concat('uikit.js'), { newLine: '\n;' })
		.pipe(gulp.dest(src.js))
		.pipe(uglify())
		.pipe(rename('uikit.min.js'))
//		.pipe(changed(build.js))
		.pipe(gulp.dest(build.js));
});

// copy fonts and flatten directory structure
gulp.task('build-fonts', function() {
	return gulp.src(src.fonts + '**/*')
		.pipe(flatten())
//		.pipe(changed(build.fonts))
		.pipe(gulp.dest(build.fonts));
});

// minify images in assets/src and save to assets/build. 
gulp.task('build-img', function() {
	return gulp.src(src.img + '**/*')
//		.pipe(changed(build.img))
//		.pipe(imagemin())
		.pipe(gulp.dest(build.img));
});

// minify new or changed HTML pages
gulp.task('build-html', function() {
	return gulp.src('_site/**/*.html')
//		.pipe(htmlmin({collapseWhitespace:true, removeComments:true}))
		.pipe(gulp.dest('_site/'));
});

gulp.task('build', function(callback) {
	browser_sync.notify('building jekyll site.');
	return child_process.spawn('bundle', ['exec', 'jekyll', 'build', '--drafts'], 
		{stdio: 'inherit'})
		.on('close', callback);
});

gulp.task('reload', function() {
	return browser_sync.reload();
});

gulp.task('serve', ['build'], function() {
	return browser_sync.init(null, {
		server: {
//			https: true,
			baseDir: '_site'
		},
		ui: false,
		port: 8000,
		open: false,
		notify: false,
		host: 'localhost'
	});
});

gulp.task('watch', function() {
	watch('./assets/src/js/**/*.js', function() {
		run_sequence('build-js', 'build', 'build-html', 'reload'); 
	});

	watch('./assets/src/less/**/*.less', function() {
		run_sequence('build-less', 'build-css', 'build', 'build-html', 'reload'); 
	});

	watch('./assets/src/css/**/*.css', function() {
		run_sequence('build-css', 'build', 'build-html', 'reload'); 
	});

	watch('./assets/src/fonts/**/*', function() {
		run_sequence('build-fonts', 'build', 'build-html', 'reload'); 
	});

	watch('./assets/src/img/**/*', function() {
		run_sequence('build-img', 'build', 'build-html', 'reload'); 
	});

	watch(['_posts/**', '*.html', '_layouts/*', '_config.yml', '_includes/**', 
	       'resources/*', '_resources/**', '_drafts/**', 'media/*', '_media/*', 
	       'blog/*', 'projects/*', '_projects/**', '_data/**', 'feed.xml'], 
	      function() {
		run_sequence('build', 'build-html', 'reload'); 
	});
});
