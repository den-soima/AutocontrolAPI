using System.Linq;
using AutocontrolService.Data.Model;

namespace AutocontrolService.Data
{
    public interface IDashboardRepository
    {
        IQueryable<Dashboard> GetAll();

    }
}