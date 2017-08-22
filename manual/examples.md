In this page, I will show some rules I have written. They are all real rules from my repos.

# `js: true` option with feature spec

I see some of Feature Spec scenarios have `js: true` option, and others do not. The reason they look strange to me is some scenarios without `js: true` depend on JavaScript. I changed one of the `js: true` to `js: false`, and run the specs again. They run! What is happening?? The `js` does not stand for *JavaScript*?? What else?

The magic happens in `rails_helper.rb`.

```rb
Capybara.configure do |config|
  config.default_driver    = :poltergeist
  config.javascript_driver = :poltergeist
end
```

Okay, `js: true` does not make any sense, because both `default_driver` and `javascript_driver` are same.

Should we fix all of the scenarios now? If we leave them, new teammates will misunderstand `js: true` does something important and required. However, we don't want to fix them now. It does not do anything bad right now. So, my conclusion is *I will do that, but not now* 😸 

It's the time to add a new Querly rule. When someone tries to add new scenario with `js: true`, tell the person that it does not make any sense.

```yaml
- id: sample.scenario_with_js_option
  pattern: "scenario(..., js: _, ...)"
  message: |
    You do not need js:true option

    We are using Poltergeist as both default_driver and javascript_driver!
  before:
    - "scenario 'hello world', js: true, type: :feature do end"
  after:
    - "scenario 'foo bar' do end"
```

No new `js: true` scenario will be written. Our new teammate may try to write that. But Querly will tell they don't have to do that, instead of me.
