using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IRoles
    {
        List<RolAplicacion> Find();
        RolAplicacion FindByUser(int userId);
    }
}
