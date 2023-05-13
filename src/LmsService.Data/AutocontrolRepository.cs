using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using LmsService.Data.Services;
using LmsService.Data.Model;
using Microsoft.EntityFrameworkCore;


namespace LmsService.Data
{
    class AutocontrolRepository : IAutocontrolRepository
    {

        private LmsContext _context;

        public AutocontrolRepository(LmsContext context)
        {
            _context = context;
        }
        public IQueryable<Autocontrol> GetAll()
        {
            var value = _context.Autocontrols.FromSqlRaw<Autocontrol>("EXECUTE [zmod].[sp_LmsAutoControlGet]");
            return value;
        }

    }
}
