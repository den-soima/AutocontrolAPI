using System;
using System.Collections.Generic;
using System.Text;

using Microsoft.EntityFrameworkCore;
using AutocontrolService.Data.Model;
using AutocontrolService.Data.Model.Report;

namespace AutocontrolService.Data.Services
{
    public class LmsContext : DbContext
    {

        public LmsContext(DbContextOptions options) : base(options)
        {

        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<ReportHeader>(val =>
            {
                val.HasNoKey().ToView(null);
            });
            modelBuilder.Entity<ReportProductionInfo>(val =>
            {
                val.HasNoKey().ToView(null);
            });
            modelBuilder.Entity<ReportMachineError>(val =>
            {
                val.HasNoKey().ToView(null);
            });
            modelBuilder.Entity<ReportStatesGraph>(val =>
            {
                val.HasNoKey().ToView(null);
            });
            modelBuilder.Entity<ReportEfficiency>(val =>
            {
                val.HasNoKey().ToView(null);
            });
            modelBuilder.Entity<ReportErrorList>(val =>
            {
                val.HasNoKey().ToView(null);
            });
            modelBuilder.Entity<Dashboard>(val =>
            {
                val.HasNoKey().ToView(null);
            });
        }
        public DbSet<Autocontrol> Autocontrols { get; set; } 

        public DbSet<Dashboard> Dashboard { get; set; }
        public DbSet<ReportLines> ReportLines { get; set; }
        public DbSet<ReportHeader> ReportHeader { get; set; }
        public DbSet<ReportProductionInfo> ReportProductionInfo { get; set; }
        public DbSet<ReportMachineError> ReportMachineError { get; set; }
        public DbSet<ReportMachineError> ReportMachineError2 { get; set; }
        public DbSet<ReportStatesGraph> ReportStatesGraph { get; set; }
        public DbSet<ReportEfficiency> ReportEfficiency{ get; set; }
        public DbSet<ReportErrorList> ReportErrorList{ get; set; }





        
    }
}
