using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface ICorreoAplicacion
    {
        List<CorreoAplicacion> Find();
        CorreoAplicacion Find(int correoAplicacionId);
        Response Save(CorreoAplicacion correoAplicacion, int currentUserId, SaveOption saveOption);
        Response ChangeState(int corcorreoAplicacionId, bool currentState, int currentUserId);

    }
}
