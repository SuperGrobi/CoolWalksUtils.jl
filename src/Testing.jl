"""

    @rerun(number, code)

runs the input `code` at most `number` times or until it does not throw an error. Used to test code which talks to a server which may not respond on every call.
"""
macro rerun(number, code)
    quote
        for i in $number:-1:1
            try
                num = $code
                break
            catch
                println("running code failed, retrying at most $i times.")
            end
            throw(ErrorException("the code did not run correctly once in $($number) tries."))
        end
    end
end