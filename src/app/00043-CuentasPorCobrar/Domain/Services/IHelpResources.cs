using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IHelpResources
    {
        Response ChangeState(int rutaDocId, bool currentState, int currentUserId);

        List<HelperResources> Find();

        List<HelperResources> Find(int rutaDocumentoId);

        Response Save(HelperResources manual, DataTable dtRoles, int currentUserId, SaveOption saveOption);
    }
}
