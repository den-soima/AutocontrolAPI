using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using AutocontrolService.Data.Services;
using AutocontrolService.Data.Model;
using Microsoft.EntityFrameworkCore;


namespace AutocontrolService.Data
{
    class DashboardRepository : IDashboardRepository
    {

        private LmsContext _context;

        public DashboardRepository(LmsContext context)
        {
            _context = context;
        }
        public IQueryable<Dashboard> GetAll()
        {
            var value = _context.Dashboard.FromSqlRaw<Dashboard>("EXECUTE [zmod].[sp_LmsDashboardFilling]");
            return value;
        }

    }
}
