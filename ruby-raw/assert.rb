def assert(rc)
  if (rc == false) || (rc != true && rc < 0)
    raise "Last API call failed at #{caller(1)}"
  end
  rc
end
