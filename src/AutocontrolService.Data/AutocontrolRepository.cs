using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;
using AutocontrolService.Data.Services;
using AutocontrolService.Data.Model;
using Microsoft.EntityFrameworkCore;


namespace AutocontrolService.Data
{
    class AutocontrolRepository : IAutocontrolRepository
    {

        private AutocontrolContext _context;

        public AutocontrolRepository(AutocontrolContext context)
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
