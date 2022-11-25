"""

    @rerun(number, code)

runs the input `code` at most `number` times or until it does not throw an error. Used to test code which talks to a server which may not respond on every call.
"""
macro rerun(number, code)
    quote
        for i in $(esc(number)):-1:1
            try
                num = $(esc(code))
                break
            catch e
                if i>1 
                    println("running code failed, retrying at most $(i-1) times.")
                else
                    rethrow(e)
                end
            end
        end
    end
end