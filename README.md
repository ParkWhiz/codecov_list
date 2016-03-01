## Description

This is a [Dashing](http://shopify.github.com/dashing) widget to display current test coverage in trends from  [Codecov](https://codecov.io/) projects.

##Dependencies

[httparty](http://johnnunemaker.com/httparty/), [octokit](http://octokit.github.io/octokit.rb), and [dotenv](https://github.com/bkeepers/dotenv)

Add it to dashing's gemfile:

    gem 'httparty'
    gem 'octokit'
    gem 'dotenv'
    
and run `bundle install`.

##Usage

To use this widget, copy `codecov_list.html`, `codecov_list.coffee`, and `codecov_list.scss` into a `/widgets/codecov_list` directory, and copy the `codecov_list.rb` file into your `/jobs` folder.


To include the widget in a dashboard, add the following snippet to the dashboard layout file:


```html
    <li data-row="1" data-col="1" data-sizex="2" data-sizey="1">
      <div data-id="codecov-list" data-view="CodecovList" data-title="Code Coverage"></div>
    </li>
```

Add a row to your `codecov_list.rb` file for each project you wish to cover.

##Settings

**API Key**: When you run dashing, you need to set the `CODECOV_TOKEN` environment variable, e.g. `CODECOV_TOKEN=YOUR_API_TOKEN dashing start`

**Coverage Changes** Each project will be color coded by upward and downard trends in coverage. `CODECOV_HORIZON` controls the number of commits over whic trends are tracked, while `CODECOV_TOLERANCE` controls the magnitude of coverage change needed to color code a project. For example, `CODECOV_HORIZON=5, CODECOV_TOLERANCE=0.5` would cause drops in coverage of at least 0.5% over the last five commits to color a project red, while increases of at least 0.5% color it green. Changes of less than ±0.5% leave the project blue

*Source Control**: Codecov requires you to specify your source control, achieved by setting `CODECOV_SOURCE`, e.g. `CODECOV_SOURCE=github`
