using Plots

#points = rand(-5:5, 5).+im*rand(-5:5, 5)
#points = [0+3im, 1+3im, 2+0im, 1-3im, 0-3im, 1+0im, 0+3im]
#points = [1+im, 1-im, -1-im, -1+im, 1+im]
points = [784-413im,779-353im,576-354im,666-490im,573-604im,778-604im,790-534im,783-535im,768-562im,754-573im,738-577im,613-577im,691-479im,622-370im,738-368im,754-375im,771-396im,776-412im,784-413im]
#points="";document.onclick=()=>{points+=`${event.clientX}-${event.clientY}im,`;console.log(points)}
evolacc = 26
convacc = 50

function idoit()
    limx = [1.5*minimum(real.(points))-maximum(real.(points))/2, 1.5*maximum(real.(points))-minimum(real.(points))/2]
    limy = [1.5*minimum(imag.(points))-maximum(imag.(points))/2, 1.5*maximum(imag.(points))-minimum(imag.(points))/2]

    number = size(points, 1)
    times = [(i-1)/(number-1) for i in 1:number]

    function c(n)
        if n==0
            sum((points[i+1]-points[i])/(times[i+1]-times[i])*(times[i+1]*(times[i+1]/2-times[i])+(times[i]^2)/2)+points[i]*(times[i+1]-times[i]) for i in 1:(number-1))
        else
            sum(im*(points[i+1]-points[i])/(2*pi*n)*exp(-im*2*pi*n*times[i+1])+(im*points[i]/(2*pi*n)+(points[i+1]-points[i])/(times[i+1]-times[i])/(4*pi^2*n^2))*(exp(-im*2*pi*n*times[i+1])-exp(-im*2*pi*n*times[i])) for i in 1:(number-1))
        end
    end

    anim = @animate for N in convert.(Int, vcat(collect(1:convacc), convacc*ones(8,1)))
        tran = 0:0.005:1

        function fseries(x)
            sum(c(i)*exp(im*i*2*pi*x) for i in (-N):N)
        end

        iaxis = imag.(fseries.(tran))
        xaxis = real.(fseries.(tran))

        plot(xaxis, iaxis, color = :yellow, xlims = limx, ylims = limy, labels = "N = $N",
                background_color = :black, foreground_color = :white, grid = true, aspectratio = 1
            )
        scatter!(real.(points), imag.(points), color = :white, labels = false, marker = :cross)
    end
    
    gif(anim, "seriesconverge.gif", fps = 8)

    anim2 = @animate for time in vcat(collect(0:0.01:1), ones(30,1))
        evolve = 0:0.001:time

        function fseries2(x)
            sum(c(i)*exp(im*i*2*pi*x) for i in (-evolacc):evolacc)
        end
        
        ievol = imag.(fseries2.(evolve))
        xevol = real.(fseries2.(evolve))

        function arbitraryf(n)
            if iseven(n)==true
                a = -n/2
                b = n/2
            else
                a = 0.5-n/2
                b = 0.5+n/2
            end
            sum(c(i)*exp(im*i*2*pi*time) for i in a:b)
        end

        phs = vcat(0, [arbitraryf(i) for i in 0:16])

        plot(xevol, ievol, color = :yellow, xlims = limx, ylims = limy, labels = "N = $evolacc",
            background_color = :black, foreground_color = :white, grid = true, aspectratio = 1
            )
        #scatter!(real.(points), imag.(points), color = :white, labels = false, marker = :cross)
        plot!(real.(phs), imag.(phs), color = :white, labels = false, alpha = 0.65)
    end

    gif(anim2, "seriesevolution.gif", fps = 30)
end

@time idoit()