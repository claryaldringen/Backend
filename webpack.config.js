module.exports = {
	entry: {
		document: './htdocs/coffee/document.coffee',
		gallery_document: './htdocs/coffee/gallery_document.coffee'
	},
	output: {
		path: '/var/www/html/Backend/htdocs/js',
		filename: '[name].js'
	},
	module: {
		loaders: [
			{
				test: /\.jsx$/,
				loader: 'babel-loader',
				exclude: /node_modules/,
				query: {
					presets: ['es2015', 'react']
				}
			},
			{
				test: /\.coffee$/,
				loader: 'coffee-loader',
				options: { sourceMap: true }
			}
		]
	},
	resolve: {
		extensions: ['.coffee','.js', '.jsx']
	},
	devtool: 'source-map',
	watch: true
};