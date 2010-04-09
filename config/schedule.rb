every :day do
  rake "backup"
end

every :hour do
  rake "ts:rebuild"
end