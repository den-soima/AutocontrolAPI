using System.Linq;
using LmsService.Data.Model.Dashboard;

namespace LmsService.Data
{
    public interface IDashboardRepository
    {
        IQueryable<DashboardData> GetData();
        IQueryable<DashboardHeader> GetHeader();
    }
}