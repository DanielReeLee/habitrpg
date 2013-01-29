helper = new require('./test/casper/helpers')()
casper = helper.casper
utils = helper.utils
url = helper.url

casper.start url + '/?play=1'

# ---------- Todos ------------
casper.then ->
  helper.reset()
  helper.addTasks()

# Gained exp on +daily
casper.then ->
  user = helper.userBeforeAfter (-> casper.click '.todos input[type="checkbox"]')
  @test.assertEquals user.before.stats.hp, user.after.stats.hp, '+todo =hp'
  @test.assert user.before.stats.exp < user.after.stats.exp, '+todo +exp'
  @test.assert user.before.stats.money < user.after.stats.money, '+todo +money'

# -daily acts as undo
casper.then ->
  user = helper.userBeforeAfter (-> casper.click '.todos input[type="checkbox"]')
  @test.assertEquals user.before.stats.hp, user.after.stats.hp, '-todo =hp'
  @test.assert user.before.stats.exp > user.after.stats.exp, '-todo -exp'
  @test.assert user.before.stats.money > user.after.stats.money, '-todo -money'

# can delete them (https://github.com/lefnire/habitrpg/issues/250)
casper.then ->
  model = helper.userBeforeAfter (-> casper.click '.todos a[data-original-title="delete"]')
  @test.assertEquals model.before.user.tasks.length - 1, model.after.user.tasks.length, 'todo deleted from user.tasks'
  @test.assertEquals model.before.user.todoIds.length -1, model.before.user.todoIds.length, 'todo deleted from user.todoIds'
  @test.assertEquals model.before._todoList.length -1, model.before._todoList.length, 'todo deleted from _todoList'

# ---------- Cron ------------
casper.then ->
  helper.reset()
  helper.addTasks()

casper.then ->
  helper.cronBeforeAfter (beforeAfter) ->
    casper.then ->
      #TODO make sure true for all todos
      todoId = beforeAfter.before.tasks.todo[0].id
#      utils.dump
#        dailyBefore:user.before.tasks[dailyId].value
#        dailyAfter:user.before.tasks[dailyId].value
      casper.test.assert beforeAfter.before.user.tasks[todoId].value < beforeAfter.after.user.tasks[todoId].value, "todo:cron:todo gained value"
      casper.test.assertEqual beforeAfter.before.user.stats.hp, beforeAfter.after.user.stats.hp, 'todo:cron:hp no change'


# ---------- Run ------------
casper.run ->
  casper.test.renderResults true