JobQueue = require "./job-queue"
vows = require "vows"
assert = require "assert"

vows.describe "job-queue"
	.addBatch
		"Test 1":
			topic: new JobQueue
			"No consumers": (jobQueue) ->
				assert.deepEqual jobQueue.consumers, []
			"No pending jobs": (jobQueue) ->
				assert.equal jobQueue.pendingJobs, 0
		"Test 2":
			topic: ->
				makeConsumer = (consumerId) ->
					(job) ->
						job.process consumerId
				jobQueue = new JobQueue [1..5].map(makeConsumer), 5, 100
				jobQueue.addConsumers [6..10].map(makeConsumer), 8, 200
				for jobId in [1..500] then do (jobId) ->
					jobQueue.enqueue
						id: jobId
						process: (consumerId) ->
				jobQueue
			"Initially":
				topic: (jobQueue) -> jobQueue
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"500 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 500
			"After 10 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 10
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"435 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 435
			"After 110 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 110
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 410
			"After 160 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 160
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"410 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 410
			"After 210 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 210
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"345 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 345
			"After 510 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 510
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"230 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 230
			"After 1010 ms":
				topic: (jobQueue) ->
					setTimeout =>
						@callback null, jobQueue
					, 1010
					undefined
				"10 consumers": (jobQueue) ->
					assert.equal jobQueue.consumers.length, 10
				"0 pending jobs": (jobQueue) ->
					assert.equal jobQueue.pendingJobs, 0
	.export module

###
process.on "uncaughtException", (err) ->
	console.error "Caught exception: " + err
	process.removeAllListeners "uncaughtException"
###