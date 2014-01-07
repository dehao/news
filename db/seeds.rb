# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

users_hash = []
(1..99).each do |i|
    users_hash << {id:i,email:"#{i}@example.com"}
end

# Guest user
users_hash << {id:100,email:"guest@example.com",guest:true}

User.seed_once(:id, users_hash)


tags = %w{虛構 邏輯錯誤 翻譯錯誤 斷章取義 廣告 未作求證 未註明來源}
tags.each do |tag|
    ActsAsTaggableOn::Tag.find_or_create_by_name(tag)
end
