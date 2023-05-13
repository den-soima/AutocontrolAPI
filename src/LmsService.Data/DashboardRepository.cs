using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using LmsService.Data.Services;
using Microsoft.EntityFrameworkCore;
using LmsService.Data.Model.Dashboard;

namespace LmsService.Data
{
    class DashboardRepository : IDashboardRepository
    {

        private LmsContext _context;

        public DashboardRepository(LmsContext context)
        {
            _context = context;
        }
        public IQueryable<DashboardData> GetData()
        {
            var value = _context.Dashboard.FromSqlRaw<DashboardData>("EXECUTE [zmod].[sp_LmsDashboardFilling]");
            return value;
        }

        public IQueryable<DashboardHeader> GetHeader()
        {
            var value = _context.DashboardHeader.FromSqlRaw<DashboardHeader>("EXECUTE [zmod].[sp_LmsDashboardFillingHeader]");
            return value;
        }


    }
}
