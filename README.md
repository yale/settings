settings
========

## read-only, entity-attribute-value settings interface

Usage:
```ruby
Settings.set_model Setting #=> supports Sequel or AR model
Settings[:entity][:attribute] #=> will refresh cache if past TTL
```
