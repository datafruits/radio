# Determing whether a list is empty or not.
def list.is_empty(l)
  list.case(true, fun (_, _) -> false, l)
end

def request.queue.pushable(~id="", ~conservative=false, ~default_duration=30., ~interactive=true, ~length=40., ~queue=[], ~timeout=20.)
  queue = ref(queue)
  def next()
    reqs = !queue
    queue := []
    reqs
  end
  def push(uri)
    log.info(label=id, "Pushing #{uri} on the queue.")
    queue := list.append(!queue, [uri])
  end
  s = request.dynamic.list(id=id, conservative=conservative, default_duration=default_duration, length=length, timeout=timeout, next)
  if interactive then
    namespace = if id == "" then "queue" else id end
    def push(uri) =
      r = request.create(uri)
      push(r)
      "OK"
    end
    server.register(namespace=namespace, description="Push a new request in the queue.", usage="push <uri>", "push", push)
    # def show_queue() =
    #   string.concat(separator=" ", list.map(fun (r) -> string_of(request.id(r)), !queue))
    # end
    # server.register(namespace=namespace, description="Display current queue content.", usage="queue", "queue", show_queue)
    def skip(_) = source.skip(s); "Done." end
    server.register(namespace=namespace, description="Skip current song.", usage="skip", "skip", skip)

    def is_ready(_) =
      "#{source.is_ready(s)}"
    end
    server.register(namespace=namespace, description="Is source ready?", usage="is_ready", "is_ready", is_ready)
    def is_up(_) =
      "#{source.is_up(s)}"
    end
    server.register(namespace=namespace, description="Is source up?", usage="is_up", "is_up", is_up)
  end
  (push, s)
end
