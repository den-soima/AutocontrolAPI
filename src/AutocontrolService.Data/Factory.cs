using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.EntityFrameworkCore;
using AutocontrolService.Data.Services;
using Microsoft.AspNetCore.Builder;

namespace AutocontrolService.Data
{
    public static class Factory
    {

        public static IServiceCollection AddDatabaseService(this IServiceCollection services, DbContextOptions contextOption)
        {
            services.AddSingleton(contextOption);
            services.AddTransient<IAutocontrolRepository, AutocontrolRepository>();
            services.AddTransient<IReportRepository, ReportRepository>();            
            services.AddTransient<AutocontrolContext>();

            return services;
        }

        public static void ConfigureDatabase(IApplicationBuilder app)
        {
            var context = app.ApplicationServices.GetRequiredService<AutocontrolContext>();
            context.Database.EnsureCreated();
        }
    }
}
