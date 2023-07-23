using System;
using System.Collections.Generic;
using System.Text;

using Microsoft.EntityFrameworkCore;
using LmsService.Data.Model.Autocontrol;
using LmsService.Data.Model.Report;
using LmsService.Data.Model.Dashboard;

namespace LmsService.Data.Services
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
            modelBuilder.Entity<DashboardData>(val =>
            {
                val.HasNoKey().ToView(null);
            });
            modelBuilder.Entity<DashboardHeader>(val =>
            {
                val.HasNoKey().ToView(null);
            });
            modelBuilder.Entity<AutocontrolFieldEnum>(val =>
            {
                val.HasNoKey().ToView(null);
            });
        }
        public DbSet<Autocontrol> Autocontrols { get; set; }
        public DbSet<DashboardData> Dashboard { get; set; }
        public DbSet<DashboardHeader> DashboardHeader { get; set; }
        public DbSet<ReportLines> ReportLines { get; set; }
        public DbSet<ReportHeader> ReportHeader { get; set; }
        public DbSet<ReportProductionInfo> ReportProductionInfo { get; set; }
        public DbSet<ReportMachineError> ReportMachineError { get; set; }
        public DbSet<ReportMachineError> ReportMachineError2 { get; set; }
        public DbSet<ReportStatesGraph> ReportStatesGraph { get; set; }
        public DbSet<ReportEfficiency> ReportEfficiency{ get; set; }
        public DbSet<ReportErrorList> ReportErrorList{ get; set; }
        public DbSet<AutocontrolField> AutocontrolFields { get; set; }
        public DbSet<AutocontrolDialog> AutocontrolDialog { get; set; }
        public DbSet<AutocontrolFieldEnum> AutocontrolFieldEnums { get; set; }








    }
}
