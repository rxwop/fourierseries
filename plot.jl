using Plots

#points = rand(-5:5, 5).+im*rand(-5:5, 5)
#points = [1 - im, 2 + 2im, -3 + 3im, -4 - 4im, 5 - 5im]
#points = [1+im, 1-im, -1-im, -1+im, 1+im]
points = [950-317im,950-371im,931-372im,918-382im,911-398im,816-717im,729-718im,682-559im,631-717im,541-716im,446-392im,433-377im,417-371im,406-370im,405-317im,582-317im,582-372im,561-373im,551-384im,553-395im,609-614im,656-465im,630-386im,621-377im,610-372im,603-371im,603-318im,769-317im,770-371im,744-373im,735-378im,733-393im,784-594im,837-396im,838-386im,834-376im,818-372im,799-372im,799-316im,951-317im]
#points="";document.onclick=()=>{points+=`${event.clientX}+${event.clientY}im,`;console.log(points)}

function idoit(sample, evolution, phasors = false)
    limx = [1.5*minimum(real.(points))-maximum(real.(points))/2, 1.5*maximum(real.(points))-minimum(real.(points))/2]
    limy = [1.5*minimum(imag.(points))-maximum(imag.(points))/2, 1.5*maximum(imag.(points))-minimum(imag.(points))/2]

    number = size(points, 1)
    times = [(i-1)/(number-1) for i in 1:number]
    
    function f(a, b, ta, tb, t, n)
        (b-a)/(tb-ta)*(exp(-im*2*pi*n*t)/(n^2*4*pi^2)+im*(t-ta)*exp(-im*n*2*pi*t)/(n*2*pi))+a*im*exp(-im*n*2*pi*t)/n/2/pi
    end

    function f2(a, b, ta, tb, n)
        f(a, b, ta, tb, tb, n)-f(a, b, ta, tb, ta, n)
    end

    function integrals(n)
        [f2(points[i], points[i+1], times[i], times[i+1], n) for i in 1:(number-1)]
    end

    function c(n)
        if n==0
            sum((points[i+1]-points[i])/(times[i+1]-times[i])*((times[i+1])^2/2-times[i+1]*times[i])+points[i]*times[i+1]-((points[i+1]-points[i])/(times[i+1]-times[i])*((times[i])^2/2-times[i]*times[i])+points[i]*times[i]) for i in 1:(number-1))
        else
            sum(integrals(n))
        end
    end

    function dotheplot()
        xran = 0:0.001:(evolution)

        function fseries(x)
            sum(c(i)*exp(im*i*2*pi*x) for i in (-sample):sample)
        end

        iaxis = imag.(fseries.(xran))
        xaxis = real.(fseries.(xran))

        
        plot(xaxis, iaxis, color = :yellow, xlims = limx, ylims = limy, labels = "N = $sample",
            background_color = :black, foreground_color = :white, grid = true, aspectratio = 1
            )
        scatter!(real.(points), imag.(points), color = :white, labels = false, marker = :cross)

        if phasors == true
            function arbitraryf(t,n)
                if iseven(n)==true
                    a = n
                else
                    a = n-1
                end
                sum(c(i)*exp(im*i*2*pi*t) for i in (-a):n)
            end

            phs = vcat(0, [arbitraryf(evolution, i) for i in 0:sample])
            widths = [1/i for i in size(phs, 1)]

            plot!(real.(phs), imag.(phs), color = :white, labels = false, alpha = 0.5)
        end
    end

    dotheplot()

    #savefig("series.png")
end

accuracy = 75

anim = @animate for i in vcat(collect(1:accuracy), accuracy*ones(8,1))
    idoit(convert(Int, i), 1)
end

anim2 = @animate for i in vcat(collect(0:0.01:1), ones(30,1))
    idoit(40, i, true)
end

gif(anim, "seriesconverge.gif", fps = 8)
gif(anim2, "seriesevolution.gif", fps = 30)

