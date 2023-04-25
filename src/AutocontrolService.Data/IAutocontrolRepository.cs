using System.Linq;
using AutocontrolService.Data.Model;

namespace AutocontrolService.Data
{
    public interface IAutocontrolRepository
    {
        IQueryable<Autocontrol> GetAll();

    }
}