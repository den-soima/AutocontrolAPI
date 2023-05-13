using System.Linq;
using LmsService.Data.Model;

namespace LmsService.Data
{
    public interface IAutocontrolRepository
    {
        IQueryable<Autocontrol> GetAll();

    }
}