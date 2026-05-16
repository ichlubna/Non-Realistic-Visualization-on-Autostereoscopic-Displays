//File: SwitchScenesBtn.cs
//Author: Aneta Chalivopulosova (xchali00)
//Description: script used to switch scenes on user's click on TAB key
//Resources: official Unity Manual and Forum (https://docs.unity3d.com/6000.0/Documentation/Manual/index.html) 
//           and Looking Glass Developer Docs (https://lfdocs.lookingglassfactory.com/software/index)

using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class SwitchScenesBtn : MonoBehaviour
{
    [Header("Movement Settings")]
    public float moveSpeed = 5f;
    public float gravity = 9.81f;
    private CharacterController controller;
    public Transform playerObject;
    public Transform scene2PositionPlayer; 
    public GameObject isActiveScene2;

    private float lockedY; 
    private Vector3 canvasOffset;

    [Header("Camera Points")]
    public Transform holoCamera; 
    public Transform scene1Position; 
    public Transform scene2Position;
    

    [Header("Canvas Points")]
    public Transform canvas; 
    public Transform scene1CanvasPos; 
    public Transform scene2CanvasPos; 

    [Header("Scene 1 Offsets")]
    public Vector3 scene1HoloPosOffset = new Vector3(0, 0, 0);
    public Vector3 scene1HoloRotOffset = new Vector3(6, 0, 0);

    [Header("Scene 2 Offsets")]
    // scene 2 holo position is: 53,-3.64,7.7 (rotation 15,0,0) and player 53,0,0 (rotation 0,0,0)
    public Vector3 scene2HoloPosOffset = new Vector3(0, -3.64f, 7.7f); // x is 0 because both are at 53 (53-53)
    public Vector3 scene2HoloRotOffset = new Vector3(15, 0, 0);

    private int activeScene;


    public void Start()
    {
        controller = GetComponent<CharacterController>();
        
        // start at scene 1
        activeScene = 1;
        GoToScene1();
        isActiveScene2.SetActive(false);
    }


    public void Update()
    {
        // TAB switches between the two scenes
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            if (activeScene == 1)
            {
                activeScene = 2;
                GoToScene2();
            }
            else
            {
                activeScene = 1;
                GoToScene1();
            }
        }

        if (activeScene == 2)
        {
            PlayerMovement();
            UpdateCanvasPosition();
            ApplyCameraFollow();
        }

    }

    public void GoToScene1()
    {
        // move camera, canvas and player to scene 1 positions 

        controller.enabled = false;

        playerObject.position = scene1Position.position;

        lockedY = scene1Position.position.y;

        holoCamera.position = scene1Position.position;
        holoCamera.rotation = scene1Position.rotation;


        canvas.position = scene1CanvasPos.position;
        canvas.rotation = scene1CanvasPos.rotation;

        canvasOffset = scene1CanvasPos.position - scene1Position.position;
        Physics.SyncTransforms();

        isActiveScene2.SetActive(false);

        controller.enabled = true;
        
    }

    public void GoToScene2()
    {
        // move camera, canvas and player to scene 2 positions 

        controller.enabled = false;

        playerObject.position = scene2PositionPlayer.position;

        lockedY = scene2PositionPlayer.position.y;
        
        canvasOffset = scene2CanvasPos.position - scene2PositionPlayer.position;
        
        Physics.SyncTransforms();

        isActiveScene2.SetActive(true);

        controller.enabled = true;

    }

    public void PlayerMovement()
    {

        float moveX = 0f;
        float moveZ = 0f;

        // WASD only (cannot use default getaxis because that also uses arrow keys)
        if (Input.GetKey(KeyCode.W)) moveZ = 1f;
        if (Input.GetKey(KeyCode.S)) moveZ = -1f;
        if (Input.GetKey(KeyCode.A)) moveX = -1f;
        if (Input.GetKey(KeyCode.D)) moveX = 1f;

        // transform.right and transform.forward to move relative to player facing
        Vector3 move = transform.right * moveX + transform.forward * moveZ;
        
        // fixed height - no gravity
        controller.Move(move * moveSpeed * Time.deltaTime);

        // lock y position
        Vector3 currentPos = transform.position;
        currentPos.y = lockedY;
        transform.position = currentPos;
    }

    private void UpdateCanvasPosition()
    {
        if (canvas != null)
        {
            // keep canvas at the same distance from the player
            canvas.position = transform.position + canvasOffset;
        }
    }

    void ApplyCameraFollow()
    {
        if (activeScene == 1)
        {
            holoCamera.position = transform.position + scene1HoloPosOffset;
            holoCamera.eulerAngles = transform.eulerAngles + scene1HoloRotOffset;
        }
        else
        {
            holoCamera.position = transform.position + scene2HoloPosOffset;
            holoCamera.eulerAngles = transform.eulerAngles + scene2HoloRotOffset;
        }
    }

    void OnDisable()
    {
        GoToScene1();
        isActiveScene2.SetActive(false);
    }
}
